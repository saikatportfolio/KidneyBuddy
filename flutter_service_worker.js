'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "9dbb2c7ca9d0d96f4e9980b31f2ecf7f",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"favicon.png": "a316aeb414a730b6c3b7943272d7aeb6",
"icons/Icon-maskable-512.png": "535019822474ec5a8d55849e624ca3a4",
"icons/Icon-maskable-192.png": "5852bac58492f16f3178118a6d91f856",
"icons/Icon-512.png": "cd1c0c21ddd11b3124d71d1a8088bffd",
"icons/Icon-192.png": "94a93d6a62c727a2cd3470bb923d8024",
"manifest.json": "4d0afe11bd5f935dac493f6692950247",
"version.json": "389a6e6e6f34312743ca5f36467c84b5",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"main.dart.js": "b3607e2a381481bb80c7c651359862a9",
"index.html": "dfccc25c2f9a84cafa0677107edd6cb6",
"/": "dfccc25c2f9a84cafa0677107edd6cb6",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/NOTICES": "c9b2770498c94175145b22f755f92f11",
"assets/AssetManifest.json": "0f9bde8a9796fa83674e0ad74213d446",
"assets/AssetManifest.bin": "a0f26ad8ea1851f027705868f6660c95",
"assets/AssetManifest.bin.json": "2dfb0cc49d4c479693b556db0660986a",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/fonts/MaterialIcons-Regular.otf": "deb3373d70d70c425ca729ce6a968770",
"assets/assets/images/home_page_thumnail.png": "61e456e44284d3463e27b8aab5b5d632",
"assets/assets/images/patient_image.png": "d879c79ad335ebb5e69ed66a8b193831",
"assets/assets/images/onboarding1.png": "32075da5f17e1779b7fd5bab3eecf6a2",
"assets/assets/images/feedback.jpg": "7d11169619134299c2c0fd7056dec27e",
"assets/assets/images/practo_icon.png": "62ff4348830cf55748ab684c0d520468",
"assets/assets/images/nutrition_guide_ckd.jpeg": "82faf7792da5548d6cd941a1343fe0d9",
"assets/assets/images/your_meal.jpg": "cf86dd52f054eab1b03dcd33322201d2",
"assets/assets/images/gfr.png": "461fa54ac71c06657b83f24ee7adeed5",
"assets/assets/images/vital.png": "6bc8522051b8b2b0d37903229395bce5",
"assets/assets/images/kidney_health.png": "847eed6e74c80f6f9fdcd0e99cd9eb5c",
"assets/assets/images/dietician.jpg": "d49a2a2e3d8b1c3319b68ab7519adb96",
"assets/assets/images/onboarding2.png": "3aa483b9d5de32e793ff1d18ed4e56e1",
"assets/assets/images/understand_ckd.jpg": "ccb85bb869e9c5be8fbbd670813b8177",
"assets/assets/images/onboarding3.png": "058ef63cfec2cd226b5b8b37d5529335",
"assets/assets/images/understand_ckd.png": "89ce8a3d2ba5dad34783f4e4ac3ba1a9",
"assets/assets/images/fill_your_details.png": "085a5350f64660574e69a06da547039d",
"assets/assets/images/praacto_splash.png": "3ed89236d886f055cc43b49888132dae",
"assets/assets/images/auth_img.jpg": "53303c27a9276715a0b628c7df9b6759",
"assets/assets/images/google_logo.png": "36807175c6e8f9441a3d31f2882d0dcf"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
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
        // Claim client to enable caching on first launch
        self.clients.claim();
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
      // Claim client to enable caching on first launch
      self.clients.claim();
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
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
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
