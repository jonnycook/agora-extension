document.getElementsByTagName('html')[0].setAttribute('agora', true);
chrome.extension.sendMessage({action:'getScriptFor', url:'http://tutorial.agora/'}, function(script) {
	eval(script)
});