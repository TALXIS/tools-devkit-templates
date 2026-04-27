
const fs = require('fs');
const vm = require('vm');
const path = require('path');

function loadWebResource(absPath) {
  if (!absPath || !fs.existsSync(absPath)) {
    throw new Error(`WEBRES_PATH not found: ${absPath}`);
  }

  const sandbox = {
    Xrm: global.Xrm,                
    window: {},                  
    document: {},                 
    console,                       
    setTimeout, clearTimeout,       
  };

  vm.createContext(sandbox);

  const code = fs.readFileSync(absPath, 'utf8');
  vm.runInContext(code, sandbox, { filename: path.basename(absPath) });

  return sandbox;
}

module.exports = { loadWebResource };
