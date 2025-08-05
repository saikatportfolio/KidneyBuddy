'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "8cfe04b496c928288051b0878c02f40d",
"assets/assets/images/google_logo.png": "36807175c6e8f9441a3d31f2882d0dcf",
"assets/assets/images/nutrition_guide_ckd.jpeg": "82faf7792da5548d6cd941a1343fe0d9",
"assets/assets/images/kidney_health.png": "edf43478b45e04ffc30e28705837c251",
"assets/assets/images/onboarding3.png": "058ef63cfec2cd226b5b8b37d5529335",
"assets/assets/images/patient_image.png": "d879c79ad335ebb5e69ed66a8b193831",
"assets/assets/images/feedback.jpg": "7d11169619134299c2c0fd7056dec27e",
"assets/assets/images/auth_image.png": "f6fe275419eda3244f6568e3c8add1d7",
"assets/assets/images/educate_ckd.png": "89ce8a3d2ba5dad34783f4e4ac3ba1a9",
"assets/assets/images/gfr.png": "461fa54ac71c06657b83f24ee7adeed5",
"assets/assets/images/onboarding1.png": "32075da5f17e1779b7fd5bab3eecf6a2",
"assets/assets/images/dietician.jpg": "d49a2a2e3d8b1c3319b68ab7519adb96",
"assets/assets/images/onboarding2.png": "3aa483b9d5de32e793ff1d18ed4e56e1",
"assets/assets/images/vital.png": "6bc8522051b8b2b0d37903229395bce5",
"assets/assets/images/your_meal.jpg": "cf86dd52f054eab1b03dcd33322201d2",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.json": "86ef60c9948fe490fc703efca5eb1c5d",
"assets/fonts/MaterialIcons-Regular.otf": "cacf7b81687d78000ac4c6f32ef7b51f",
"assets/AssetManifest.bin.json": "fe37c49c35d08d19d2442d0927f5a271",
"assets/NOTICES": "32dc035a6dc82c3cb9277fa211fb0e45",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/mixpanel_flutter/assets/mixpanel.js": "48a5241deca6bca875259d2b562d7081",
"version.json": "389a6e6e6f34312743ca5f36467c84b5",
"manifest.json": "b19362383014fc8ebdd964dcfcb0c617",
"flutter_bootstrap.js": "212601459fd330e89efa95801c2ba421",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"index.html": "f8547051828c22f7fea41e9616fec479",
"/": "f8547051828c22f7fea41e9616fec479",
"favicon.png": "a316aeb414a730b6c3b7943272d7aeb6",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"icons/Icon-512.png": "cd1c0c21ddd11b3124d71d1a8088bffd",
"icons/Icon-192.png": "94a93d6a62c727a2cd3470bb923d8024",
"icons/Icon-maskable-512.png": "535019822474ec5a8d55849e624ca3a4",
"icons/Icon-maskable-192.png": "5852bac58492f16f3178118a6d91f856",
"main.dart.js": "dd6fc765ea4847ad877ffb18d9e5ed97"};
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
