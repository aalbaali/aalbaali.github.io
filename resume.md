+++
cover=true
+++

@@bio

@@pt-4 @@

~~~
<div id="adobe-dc-view" style="width: 800px;"></div>
<script src="https://documentservices.adobe.com/view-sdk/viewer.js"></script>
<script type="text/javascript">
	document.addEventListener("adobe_dc_view_sdk.ready", function(){ 
		var adobeDCView = new AdobeDC.View({clientId: "676d9d7756714b6ba13a6025f9f1be32", divId: "adobe-dc-view"});
		adobeDCView.previewFile({
			content:{location: {url: "/assets/resume.pdf"}},
			metaData:{fileName: "resume.pdf"}
		}, {embedMode: "IN_LINE"});
	});
</script>
~~~

@@pt-5 @@

@@ <!-- end of bio div -->
