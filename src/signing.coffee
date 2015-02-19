crypto = require("crypto")

module.exports = (data, secret) ->
  base64data = new Buffer(data, "UTF-8").toString("base64")
  signedHash = crypto.createHmac("sha256", secret).update(base64data).digest("base64")
  signedHash
