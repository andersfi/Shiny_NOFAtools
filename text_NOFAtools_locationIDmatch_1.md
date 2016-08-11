## Find locationID from existing data ##
NOFA uses locationIDs that are different from national WaterbodyIDs (like vatn_lnr from Norway, or SMHI_id in Sweden). The reason is simply that quite a few watebodies cross national borders and thus gets several official waterbodyIDs. This tool is for helping match nationalWaterbodyIDs to NOFA locationIDs

Upload a .csv file, and make sure that file contains a column named waterbodyID. Hint: you can save the file as .csv using the save as' function in most spreadsheet editors, like Microsoft-XL or OpenOffice Calc. You can also download a testfile for trying it out [here](https://ntnu.box.com/shared/static/1711m1d3ywpd8wc82m5oq05gg7tvrw5p.csv). 

Currently, only Norwegian national waterbodyID's given by NVE (vatn_lnr) are supported.
