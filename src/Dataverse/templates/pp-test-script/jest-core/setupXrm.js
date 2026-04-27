function ensureJsDom() {
    if (typeof window === 'undefined') {
      global.window = {};
    }
    if (typeof document === 'undefined') {
      global.document = {};
    }
  }
  
  function makeFn() {
    return global.jest && jest.fn ? jest.fn() : () => {};
  }
  
  function buildDefaultXrm() {
    return {
      Navigation: {
        openDialog: makeFn(),
        openAlertDialog: makeFn(),
        openErrorDialog: makeFn(),
        close: makeFn()
      },
      Utility: {
        getEntityMetadata: makeFn(),
        showProgressIndicator: makeFn(),
        closeProgressIndicator: makeFn(),
        getGlobalContext: makeFn()
      },
      WebApi: {
        createRecord: makeFn(),
        retrieveRecord: makeFn(),
        updateRecord: makeFn(),
        deleteRecord: makeFn(),
        retrieveMultipleRecords: makeFn()
      },
      Device: {
        getBarcodeValue: makeFn(),
        getCurrentPosition: makeFn()
      },
      Page: undefined
    };
  }
  
  function setupXrm() {
    ensureJsDom();
    if (!global.Xrm) {
      global.Xrm = buildDefaultXrm();
    } else {
      const d = buildDefaultXrm();
      for (const k of Object.keys(d)) {
        if (!global.Xrm[k]) global.Xrm[k] = d[k];
        else {
          for (const mk of Object.keys(d[k])) {
            if (typeof global.Xrm[k][mk] === 'undefined') {
              global.Xrm[k][mk] = d[k][mk];
            }
          }
        }
      }
    }
  
    if (!global.window.parent) {
      global.window.parent = {};
    }
    if (!global.window.parent.Xrm) {
      global.window.parent.Xrm = global.Xrm;
    }
  }
  
  function resetXrmMocks() {
    if (!global.Xrm) return;
  
    const walk = (obj) => {
      if (!obj) return;
      for (const key of Object.keys(obj)) {
        const v = obj[key];
        if (typeof v === 'function' && v.mock && typeof v.mockReset === 'function') {
          v.mockReset();
        } else if (v && typeof v === 'object') {
          walk(v);
        }
      }
    };
    walk(global.Xrm);
  }
  
  module.exports = { setupXrm, resetXrmMocks, ensureJsDom };
  