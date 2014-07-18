({ 
  baseUrl: "build/lib/",
  paths: {
    ChromeBackground: "../ChromeBackground",
    ChromeContentScript: "../ChromeContentScript",
    underscore: "../../libs/lodash.min",
    jQuery: "../../libs/jquery-1.7.2.min",
		text: "../../libs/text",
		taxonomySrc: "../../taxonomy"
  },
  shim: {
    underscore: {
      exports: "_"
    },
    jQuery: {
      exports: "$"
    }
  },
  name: "Agora",
  out: "agora-built.js",
  // optimize: "none",
  uglify: {
    no_mangle: true
  },
  include: ["../../all.js", "Background"]
})
