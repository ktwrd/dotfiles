const addons = require("./addons.json").addons
addons.forEach(a => a.name != undefined ? console.log(`${a.type}: ${a.name}@${a.version}`) : null )