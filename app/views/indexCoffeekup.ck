doctype 5
html ->
  head ->
    title -> @title
    script src: 'https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js'
    script src: '/socket.io/socket.io.js'
    @js 'application.js'
    @css 'style.css'
  body ->
      h1 -> @title
      a href: "/app", -> 'Login'
