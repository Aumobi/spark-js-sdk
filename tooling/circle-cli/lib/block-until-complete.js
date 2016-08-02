'use strict';

const _ = require(`lodash`);

module.exports = _.curry(function blockUntilComplete(argv, ci, build) {
  return ci.getBuild(build)
    .then((result) => {
      // eslint-disable-next-line camelcase
      let str = ``;
      if (!process.env.HUDSON_URL) {
        str += `${(new Date()).toISOString()}: `;
      }
      str += `build number ${result.build_num} has status ${result.status} and lifecyle ${result.lifecycle} on Circle CI`;
      if (result.start_time) {
        str += ` (started at ${result.start_time})`;
      }
      else if (result.usage_queued_at) {
        str += ` (queued at ${result.usage_queued_at})`;
      }
      console.log(str);
      if ([`finished`, `not_run`].indexOf(result.lifecycle) !== -1) {
        return new Promise((resolve) => {
          setTimeout(() => resolve(blockUntilComplete(argv, ci, build)), argv.interval);
        });
      }

      return result;
    })
    .catch((reason) => {
      if (reason.code === `ENOTFOUND`) {
        console.warn(`ENOTFOUND returned when fetching build status`);
        return blockUntilComplete(argv, ci, build);
      }
      return Promise.reject(reason);
    });
});
