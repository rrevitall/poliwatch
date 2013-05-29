Model = require('op-tools/voting-record/aph/model')()
require 'sequelize-restful'

sql = require 'sql'
squel = require 'squel'
_ = require 'underscore'
marked = require 'marked'
cheerio = require 'cheerio'

{parse} = require('helpers/util').Util

class @Divisions

  @index: (req, res, next) ->
    await Model.Division.findAll().done defer e, r
    return next e if e
    r = parse r, 'json'
    res.send r

  @show: (req, res, next) ->
    id = req.params.division
    await Model.Division.findWithBills id, defer e, model, bills
    return next e if e
    model = parse model, 'json'

    parseSpeeches model.json.speeches

    {firstSpeaker, speakers} = extractSpeakers model.json.speeches

    splitSpeechBodiesIntoSpans model.json.speeches

    bills = _.map bills, (b) ->
      b = parse b, 'json'
      b

    # Index sheets of proposed amendments.
    proposedAmendments = indexSheetsOfProposedAmendments bills

    # Add links for each sheet reference.
    mentionedAmendments = linkifySheetReferences model.json.speeches, proposedAmendments

    _.extend model,
      bills: bills
      mentionedAmendments: mentionedAmendments
      speakers: speakers
    res.send model

parseSpeeches = (speeches) ->
  for s in speeches
    s.speakerImage = "http://parlinfo.aph.gov.au/parlInfo/download/handbook/allmps/#{s.mpid}/upload_ref_binary/#{s.mpid}.jpg"

extractSpeakers = (speeches) ->
  speakers = {}
  firstSpeaker = speeches[0]
  for s in speeches
    speakers[s.speakerId] = s
  {firstSpeaker, speakers}

splitSpeechBodiesIntoSpans = (speeches) ->
  for s in speeches
    $ = cheerio.load s.content
    $('p').each ->
      html = @html()
      sentences = html.match /[^\.!\?]+[\.!\?]+/g
      if sentences?
        html = sentences.map( (s) -> "<span>#{s}</span>" ).join('')
        @html html
    s.content = $.html()

linkifySheetReferences = (speeches, proposedAmendments) ->
  mentionedAmendments = {}
  for s in speeches
    regex = /(sheet )(\d+)/
    s.content = s.content.replace regex, (m, $1, $2) ->
      mentionedAmendments[$2] = proposedAmendments[$2]
      "<a href='/sheet/#{$2}'>#{$1}#{$2}</a>"
  mentionedAmendments

indexSheetsOfProposedAmendments = (bills) ->
  proposedAmendments = {}
  for bill in bills
    for amendment in bill.json.proposedAmendments
      [matches, party, sheet, name] = (amendment.title.match /(.*) \[sheet (\d+)\](.*)?/) or []
      continue unless matches?

      html = cleanAndRenderAmendment amendment.markdown

      proposedAmendments[sheet] =
        party: party
        name: name
        markdown: amendment.markdown
        html: html
        link: amendment.link
  proposedAmendments

cleanAndRenderAmendment = (md) ->
  # Remove everything before first heading.
  # TODO: This should be moved into voting-record.
  html = marked md
  $ = cheerio.load html
  $("o\\:p").remove()
  $('p').filter -> @remove() unless @text().length
  $.root().children().each ->
    return false if @[0].name is 'h1'
    @remove()
  # Proper indents for ensp;
  $('p').each ->
    html = @html()
    # Count leading &ensp;
    count = 0
    @html html.replace /^([\u2002]+)/g, (match, p1, offset) ->
      count = p1.match(/\u2002/g)?.length
      ''
    @replaceWith "<p style='padding-left:#{count/10}em'>#{@html()}</p>"

  html = $.html()

sequelizeModelToNodeSql = (sql, model) ->
  sql.define
    name: model.name
    columns: (k for k, v of model.rawAttributes)

#setTimeout ->
#
#  division = sequelizeModelToNodeSql sql, Model.Division
#  member = sequelizeModelToNodeSql sql, Model.Member
#  memberVote = sequelizeModelToNodeSql sql, Model.MemberVote
#
#  getAllDivisionsForMember = division
#    .join(memberVote).on(memberVote.divisionId.equals(division.id))
#    .join(member).on(memberVote.memberId.equals(member.id))
#
#  console.log getAllDivisionsForMember.toQuery().text
#
#, 500
