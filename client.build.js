({
  baseUrl: "build/lib/",
  paths: {
    ChromeBackground: "../ChromeBackground",
    ChromeContentScript: "../ChromeContentScript",
    underscore: "../../libs/lodash.min",
    jQuery: "../../libs/jquery-1.7.2.min"
  },
  shim: {
    underscore: {
      exports: "_"
    },
    jQuery: {
      exports: "$"
    }
  },
  // name: "Agora",
  out: "client.agora-built.js",
  uglify: {
    no_mangle: true
  },
  include: ["../../client_all.js"]
})
