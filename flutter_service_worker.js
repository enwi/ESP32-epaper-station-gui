'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  ".git/COMMIT_EDITMSG": "d18782f2ce7e5fcd39e10a660ae2c69f",
".git/config": "daa2fa205c9e5b2489b22e2cdcbffd20",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "39d73b4368e8bec1ab6a47ee96817cfc",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "ea587b0fae70333bce92257152996e70",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "305eadbbcd6f6d2567e033ad12aabbc4",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "660c3e22e5dc51fb7d7713f6bc16afa5",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "f7f464d366a2abe414fdd4c4071dbae3",
".git/logs/refs/heads/main": "d7c706b693dce14f53512751d38f04a7",
".git/logs/refs/heads/page": "8b891a66db2a9aa34d3780ebfb9c0b85",
".git/logs/refs/remotes/origin/HEAD": "d7c706b693dce14f53512751d38f04a7",
".git/logs/refs/remotes/origin/page": "d7093aafac07095b95c55c4177ae0515",
".git/logs/refs/stash": "320ff419831550f955c1663bef5b5514",
".git/objects/0c/53d3db8b8e88345b13e7143cca525735a7353a": "1866933fe925d27bcd357e76f48e78c4",
".git/objects/10/a3caa0e4ca2efa5648a79ac885d3b3b1e39824": "743badcec605c4e4fb6d1f0db3aacffc",
".git/objects/12/0ae8a8d9c13b784bd4ca90e64aa65460d616ca": "e4e8f15cf08ed81ef2a56bac2897a93f",
".git/objects/1d/a03286a0605619cbe26c021e1b820baf9aedb0": "a4f47acb1a7a6419ed0c51e124531ffe",
".git/objects/2c/d8883d879fe12817579bab38bea27a444bba65": "7db1f1230880474cb3db385f0deded84",
".git/objects/49/2e3eb585c16ac2c4810a250b62062d67f83c21": "61c104f3b08eff411abd62022cd8f1ad",
".git/objects/5f/42a48d8ca08f6330d6fc6f7dd23bab8f0faa66": "520463420d3787de1f54f9ec65226432",
".git/objects/9a/b5edac623f1251bddefab0a46d49598ba7a607": "6edf3e54b7096a377842b6d75b80a7b7",
".git/objects/9d/953ab836b5066711fa4d0e80277ffabd9435f8": "7a6532aef0e48520434065ac1ca47ec9",
".git/objects/c4/acaf5d4c1a6833fd28fdb4e69d756ee4fadd7e": "3d3e0a200483dbb45bd8654401709882",
".git/objects/cb/bc4351bc0e6eb34386b8d2931463d374a5bb20": "e6922269ec9ac1fac7a75179a7ca48d5",
".git/objects/d8/b218af8378918d71fb4f475f7b3d77d0a13d98": "3f5b39587393613fb69946e88f220351",
".git/objects/ec/ed010b1b49935b0e5b9a62e51f94010ee6fbf9": "d601082ba67fdb64b380f0ea364990c6",
".git/objects/pack/pack-96be071b766405e9779814836d55bb7332734c60.idx": "a378c6846d1de266f0dc465fe527db1d",
".git/objects/pack/pack-96be071b766405e9779814836d55bb7332734c60.pack": "12c90784c8396c2714e377187b91e7f4",
".git/ORIG_HEAD": "719c225f8ac61457d63a10dd8dc37aa6",
".git/packed-refs": "1809f214d37d0a50dc988fb4db4fe52d",
".git/refs/heads/main": "719c225f8ac61457d63a10dd8dc37aa6",
".git/refs/heads/page": "8da5fe54eac6650967c580c02fa836f4",
".git/refs/remotes/origin/HEAD": "98b16e0b650190870f1b40bc8f4aec4e",
".git/refs/remotes/origin/page": "8da5fe54eac6650967c580c02fa836f4",
".git/refs/stash": "f1abf632fabceafae656af8bd8ce75bd",
"assets/AssetManifest.json": "2efbb41d7877d10aac9d091f58ccd7b9",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "95db9098c58fd6db106f1116bae85a0b",
"assets/NOTICES": "4812ac86e1cdd4986c96de0bfaf401ce",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"canvaskit/canvaskit.js": "3725a0811e16affbef87d783520e61d4",
"canvaskit/canvaskit.wasm": "4b83d89d9fecbea8ca46f2f760c5a9ba",
"canvaskit/profiling/canvaskit.js": "491df729e7b715d86fc167feabea031a",
"canvaskit/profiling/canvaskit.wasm": "95e736ab31147d1b2c7b25f11d4c32cd",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "2556c7a0a389efe39748bf8869544837",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "7653f27d7b18c992c1367bd9aeceb093",
"/": "7653f27d7b18c992c1367bd9aeceb093",
"LICENSE": "b1ac9cb0fd941d286954077c2375b74f",
"main.dart.js": "143093a4395667c12c128e4092ec3330",
"manifest.json": "2caefd4f7abd4a5c208981e992d1e341",
"README.md": "6145ecdd61114243e4a9d954289c6790",
"version.json": "99e40aefee9128cdcee1c40741f8b58b"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
