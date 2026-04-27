const setup = require('./setupXrm');
const helpers = require('./helpers');

module.exports = {
  setupXrm: setup.setupXrm,
  resetXrmMocks: setup.resetXrmMocks,
  ensureJsDom: setup.ensureJsDom,
  ...helpers
};
