Model = require('op-tools/voting-record/aph/model')()

class @Bills

  @show: (req, res, next) ->
    id = req.params.bill
    await Model.Bill.find(id).done defer e, model
    return next e if e
    res.send model
