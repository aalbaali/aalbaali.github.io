+++
cover=true
+++

@@resume-container

~~~
<div id="adobe-dc-view" style="height:1100px; width=2760px"></div>
<script src="https://documentservices.adobe.com/view-sdk/viewer.js"></script>
<script type="text/javascript">
	var isProd = window.location.hostname === "aalbaali.github.io";

	if (isProd) {
		document.addEventListener("adobe_dc_view_sdk.ready", function(){ 
			var adobeDCView = new AdobeDC.View({clientId: "676d9d7756714b6ba13a6025f9f1be32", divId: "adobe-dc-view"});
			adobeDCView.previewFile({
				content:{location: {url: "/assets/resume.pdf"}},
				metaData:{fileName: "resume.pdf"}
			},
			{
		  	embedMode: "SIZED_CONTAINER",
				defaultViewMode: "FIT_WIDTH",
				showFullScreen: true,
				showDownloadPDF: true,
				exitPDFViewerType: "CLOSE",
		  });
		});
	} else {
		// Adobe's Client ID is only allowlisted for the production domain, so
		// non-prod hosts (localhost, LAN IPs, etc.) fall back to the browser's
		// native PDF viewer instead of hitting a domain-authorization error.
		document.getElementById("adobe-dc-view").innerHTML =
			'<iframe src="/assets/resume.pdf" width="100%" height="1100px" style="border:none;"></iframe>';
	}
</script>
~~~

@@ <!-- end of resume div -->
