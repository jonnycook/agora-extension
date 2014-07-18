<html agoraparams='{"base":"http://webapp.agora.dev/webapp.php"}'>
<head>
	<title>Agora</title>
	<script type="text/javascript">
		if (!document.getElementsByTagName('html')[0].getAttribute('agora')) {
			function addScript(src) {
				var script = document.createElement('script');
				var url;
				if (window.chrome && chrome.extension) {
					url = chrome.extension.getURL(src);
				}
				else {
					url = src;
				}
				script.setAttribute('src',url);
				document.getElementsByTagName('head')[0].appendChild(script);
			}

			var env = {
				// domain: '66.228.54.96/ext',
				domain: 'ext.agora.dev',
				// updaterHost: 'localhost',
				// autoUpdate:true,
				// localTest:true,
				dontSubmitErrors:true,
				dev:true,
				debug:true,
				chat:false,
				scraping: false,
				core:true,
				tracking:false,
				stylesheet: 'dev',
				root: 'http://webapp.agora.dev',
				base: 'http://webapp.agora.dev/webapp.php'
			};


				/*'<script type="text/javascript" src="/agora-built.js"></ script' + '>' +
				'<script type="text/javascript" src="/client.agora-built.js"></ script' + '>' +*/


			document.write(
				'<script type="text/javascript" src="/build/tracking.js"></script' + '>' +
				'<script type="text/javascript" src="/build/require.config.js"></script' + '>' +
				'<script type="text/javascript" src="/libs/require.js"></script' + '>' +
				'<script type="text/javascript" src="/build/webapp/bootstrap.js"></script' + '>'
			);
		}
	</script>
</head>
<body>
</body>
</html>
