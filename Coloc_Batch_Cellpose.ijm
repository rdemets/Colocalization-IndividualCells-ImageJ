// This macro aims to quantify the colocalization coefficient of individual cells in a monolayer
// All function used are available from the stable version of Fiji and PTBIOP plugin.
// Requires installation of cellpose through Anaconda
// 

// Macro author R. De Mets
// Version : 0.1.1 , 11/08/2023




macro "Cell Mask Button Action Tool - C000D63DfdC000D59DbcC000D17C000DddC000D38C000Da5C000D8aC000D04C000D74C111DabC111DedC111D06C111Dc7C111DfbC111D05C111D69C111D53Db6C111De9DfcC111D43C111C222Dd8C222D34C222D27C222D48C222D95C333DccC333C444D85C444D9aC444D24C444C555D79C555D64DeaC555C666D14C666DbbC666C777D58C888D16C888Da6C999D37C999CaaaDc8CaaaDdcCaaaD44CaaaD89Db7CaaaDaaCaaaCbbbD75CbbbDecCbbbDd9CbbbDebCbbbCcccD15CcccD54CcccD68CdddD26CdddCeeeDcbCeeeD35CeeeD47CeeeD96CeeeD86CeeeD99CfffD25D65CfffD78CfffDbaCfffDdaCfffD45Db8CfffDa7CfffD36D57Dc9CfffDdbCfffD46D55D56D66D67D76D77D87D88D97D98Da8Da9Db9Dca"{

	//setBatchMode(true);
	run("Close All");
	dirS = getDirectory("Choose source Directory");
	pattern = ".*"; // for selecting all the files in the folder
	iter = 1;	
	N_Image = 3;
	counter = 1;
	filenames = getFileList(dirS);
	counter = 0;
		
	// Open each file
	for (i = 0; i < filenames.length; i++) {
	// Open file if CZI
		currFile = dirS+filenames[i];
		if(endsWith(currFile, ".czi") && matches(filenames[i], pattern)) { // process czi files matching regex
			//open(currFile);
			run("Clear Results");
			roiManager("reset");
			run("Bio-Formats Windowless Importer", "open=[" + currFile+"]");
			window_title = getTitle();
			getDimensions(width, height, channels, slices, frames);
			getPixelSize(unit, pw, ph, pd);
			title = File.nameWithoutExtension;
			
			// prompt for the first iteration to identify membrane and nuclei channels
			if (iter) {
				iter = 0;
				Dialog.create("Channel to analyse");
				Dialog.addNumber("Channel with membrane", "1");
				Dialog.addNumber("Channel with nuclei", "3");
				Dialog.show();
				ch1 = Dialog.getNumber();
				ch2 = Dialog.getNumber();
			}
			
			// pick x number of images within the stacks
			for (n = 1; n <= N_Image; n++) {
				sliceToPick = n*round(slices/(N_Image+1));
				roiManager("reset");
				progress = counter/(filenames.length*N_Image)*100;
				counter = counter+1;
				prompt =" "+progress+"% - Processing image: "+window_title+" for Z = "+sliceToPick;
				print(prompt);
				selectWindow(window_title);
				run("Duplicate...", "duplicate slices="+sliceToPick);
				rename(title+sliceToPick);
				
				// if staining is membrane, need to invert to mimick cytoplasm staining
				setSlice(ch1);
				run("Invert", "slice");
				
				// run cellpose on individual Z. Diameter set at 200. Can be changed
				run("Cellpose Advanced", "diameter=200 cellproba_threshold=0.0 flow_threshold=0.4 anisotropy=1.0 diam_threshold=12.0 model=cyto2 nuclei_channel="+ch2+" cyto_channel="+ch1+" dimensionmode=2D stitch_threshold=-1.0 omni=false cluster=false additional_flags=");
				run("Label image to ROIs", "rm=[RoiManager[size=30, visible=true]]");
				roiManager("Save", dirS+title+"_Z"+sliceToPick+".zip");
				
				// invert back membrane staining
				selectWindow(title+sliceToPick);
				setSlice(ch1);
				run("Invert", "slice");
				saveAs("Tiff", dirS+title+"_Z"+sliceToPick+".tif");
				close();

			}	
			run("Close All");				
		}
	}
	
	Dialog.create("Done");
	Dialog.show();
}


macro "Colocalization Button Action Tool - C010D02D20C500D7fDf7C0f0D83C000DdfDfdC0f0D13D14D15D16D17D18D22D23D24D25D26D27D28D29D31D32D33D34D35D36D37D41D42D43D44D45D51D52D53D54D61D62D63D71D72D73D81D82D92Cf00D5cD6cD9bDb9Cfd0Db6C0b0D07D70Cf00D6dD7cD7dD8cD8dD8eD9cD9dD9eDabDacDadDaeDbaDbbDbcDbdDbeDc7Dc8Dc9DcaDcbDccDcdDd6Dd7Dd8Dd9DdaDdbDdcDddDe8De9DeaDebCf10DaaC100DeeCff0D57D58D59D5aD66D67D68D69D6aD75D76D77D78D79D7aD85D86D87D88D89D95D96D97D98D99Da5Da6Da7C060D08D80Cc00DafDfaC3f0D55C010D09D2bD90Db2Cfe0Da8C0e0D06D60Cfa0Db7C500DcfDfcC030D11Ca00D8fDf8C1f0D93C100D4dD6fDd4Df6Cfe0Db5C0c0D04D12D21D40Cf40D8bC200D5eDe5C0b0D19D2aD91Da2Cf00D7eDceDe7DecCbb0Db4Cff0D8aC0f0D05D50Cdf0D49D4aD94Da4C020D1aDa1C900DdeDedC1f0D3aDa3Cf20Dc5C070D03D30Cc00D9fDf9Cba0D4bCfc0D5bD6bC050D3bDb3Cb00D5dD6eDd5De6C2f0D46Cf90D7bD9aCcf0D65C600D4cC1f0D38Cf10Dc6C8f0D47D74C2f0D39D64Cf80Da9Ccf0D84Ca00DbfDfbCf40Db8Cdf0D48D56C610Dc4"{


	run("Close All");
	dirS = getDirectory("Choose source Directory");
	pattern = ".*"; // for selecting all the files in the folder
	filenames = getFileList(dirS);
	iter = 1;
	count = 0;
	run("Clear Results");		
	// Open each file
	for (i = 0; i < filenames.length; i++) {
		currFile = dirS+filenames[i];
		
		// open if tif and open associated zip file with cell rois
		if(endsWith(currFile, ".tif") && matches(filenames[i], pattern)) { // process czi files matching regex
			//open(currFile);
			roiManager("reset");
			run("Bio-Formats Windowless Importer", "open=[" + currFile+"]");
			
			window_title = getTitle();
			getDimensions(width, height, channels, slices, frames);
			getPixelSize(unit, pw, ph, pd);
			title = File.nameWithoutExtension;
			roiManager("Open", dirS+File.separator+title+".zip");
			
			// ask once for the two channels to analyze for colocalization
			if (iter) {
					Dialog.create("Channel to analyse");
					Dialog.addNumber("Channel 1 to analyse", "2");
					Dialog.addNumber("Channel 2 to analyse", "4");
					Dialog.addCheckbox("Shrink cell borders (1um)", false);
					Dialog.addCheckbox("Save reports", true);
					Dialog.show();
					ch1 = Dialog.getNumber();
					ch2 = Dialog.getNumber();
					Shrink = Dialog.getCheckbox();
					Report = Dialog.getCheckbox();
					
					iter=0;
					
					// ask for thresholding methods to be applied on all images
					setSlice(ch1);
					run("Threshold...");
					waitForUser("Find the good threshold method for channel A and click OK");
					threshold_ch1 = getInfo("threshold.method");
					setSlice(ch2);
					run("Threshold...");
					waitForUser("Find the good threshold method for channel B and click OK");
					threshold_ch2 = getInfo("threshold.method");
					setBatchMode(true);
					
			}
			if (Shrink) {
				n=roiManager("count");
				for (roi = 0; roi<n; roi++) {
					roiManager("Select", roi);
					run("Enlarge...", "enlarge=-1");
					roiManager("Update");
				}
			}
			
			
			run("BIOP JACoP", "channel_a="+ch1+" channel_b="+ch2+" threshold_for_channel_a="+threshold_ch1+" threshold_for_channel_b="+threshold_ch2+" manual_threshold_a=0 manual_threshold_b=0 crop_rois get_pearsons get_spearmanrank get_manders get_overlap get_li_ica get_fluorogram costes_block_size=5 costes_number_of_shuffling=100");
			if (Report) {
				foldersave = dirS + File.separator + "ReportPNG";
				File.makeDirectory(foldersave);
				n=roiManager("count");
				temptitle = File.nameWithoutExtension;
				for (RepSave = n; RepSave>0; RepSave--) {
					title = foldersave+File.separator+temptitle+"cell_"+RepSave+".png";
					saveAs("PNG", title);
					close();
				}
			}
			run("Close All");
		}
	}
	selectWindow("Results");
	saveAs("Text", dirS + "Colocalization_Analysis.csv");
	Dialog.create("Done");
	Dialog.show();

}

