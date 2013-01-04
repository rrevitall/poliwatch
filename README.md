# Express Bootstrap

I use this for every new Express project.

## Checkout

  mkdir yourappname
  cd yourappname
  git clone https://github.com/vjpr/express-bootstrap.git .

If using IntelliJ, `File > Open...` and select `yourappname` dir you just created.

## Setup

    heroku apps:create yourappname
    heroku addons:add mongolab:starter
    heroku addons:add redistogo:nano
    heroku config:add NODE_ENV=production

See https://devcenter.heroku.com/articles/nodejs for more.

### If you want Facebook Authentication

Add to `/etc/hosts`

    127.0.0.1    localhost.yourappname.herokuapp.com

Create app at <https://developers.facebook.com/apps>

Fill in the following details at the bottom of the page.

    Website with Facebook login > Site URL: http://yourappname.herokuapp.com/
    App Domains:
      - localhost.yourappname.herokuapp.com
      - yourappname.herokuapp.com

Paste `appId` and `appSecret` into `src/config.coffee`.

Modify `appName` in `src/config.coffee` to your Heroku app name.

Modify `name` in `package.json`.

Install, then run `make`.

Visit <http://localhost:3030/>

## Install

Make sure you are using Node 0.8.x.

    npm install nodemon -g
    npm install

## Dev

    make
    
Visit <http://localhost:3030>

## Debug

See <https://github.com/dannycoates/node-inspector>

    node --debug-brk app
    node-inspector &
    
 Visit <http://127.0.0.1:8080/debug?port=5858>
 
## TODO
