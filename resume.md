+++
cover=true
+++

@@resume-container

~~~
<div id="adobe-dc-view" style="height:1100px; width=2760px"></div>
<script src="https://documentservices.adobe.com/view-sdk/viewer.js"></script>
<script type="text/javascript">
	document.addEventListener("adobe_dc_view_sdk.ready", function(){ 
		var adobeDCView = new AdobeDC.View({clientId: "b85d81c45c9c4a18875912a43b8f6c05", divId: "adobe-dc-view"});
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
</script>
~~~

@@ <!-- end of resume div -->
