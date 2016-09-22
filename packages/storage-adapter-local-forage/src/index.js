/**!
 *
 * Copyright (c) 2015-2016 Cisco Systems, Inc. See LICENSE file.
 * @private
 */

 /* eslint-env browser */

import localforage from 'localforage';

import {NotFoundError} from '@ciscospark/spark-core';

const namespaces = new WeakMap();
const loggers = new WeakMap();

/**
* IndexedDB adapter for spark-core storage layer
*/
export default class StorageAdapterIndexedDB {
  /**
   * @constructs {StorageAdapterIndexedDB}
   * @param {string} basekey localforage key under which
   * all namespaces will be stored
   */
  constructor() {
    /**
     * localforage binding
     */
    this.Bound = class {
      /**
       * @constructs {Bound}
       * @param {string} namespace
       * @param {Object} options
       */
      constructor(namespace, options) {
        namespaces.set(this, namespace);
        loggers.set(this, options.logger);
      }

      /**
       * Removes the specified key
       * @param {string} key
       * @returns {Promise}
       */
      del(key) {
        loggers.get(this).info(`local-forage-store-adapter: deleting \`${key}\``);
        return localforage.removeItem(key);
      }

      /**
       * Retrieves the data at the specified key
       * @param {string} key
       * @returns {Promise<mixed>}
       */
      get(key) {
        return new Promise((resolve, reject) => {
          loggers.get(this).info(`local-forage-store-adapter: reading \`${key}\``);

          return localforage.getItem(key)
            .then((value) => {
              if (value) {
                return resolve(value);
              }
              return reject(new NotFoundError(`No value found for ${key}`));
            });
        });
      }

      /**
       * Stores the specified value at the specified key
       * @param {string} key
       * @param {mixed} value
       * @returns {Promise}
       */
      put(key, value) {
        loggers.get(this).info(`local-forage-store-adapter: writing \`${key}\``);
        return localforage.setItem(key, value);
      }
    };
  }

  /**
  * Returns an adapter bound to the specified namespace
  * @param {string} namespace
  * @param {Object} options
  * @returns {Promise<Bound>}
  */
  bind(namespace, options) {
    options = options || {};
    if (!namespace) {
      return Promise.reject(new Error(`\`namespace\` is required`));
    }

    if (!options.logger) {
      return Promise.reject(new Error(`\`options.logger\` is required`));
    }

    options.logger.info(`local-forage-store-adapter: returning binding`);

    return Promise.resolve(new this.Bound(namespace, options));
  }
}