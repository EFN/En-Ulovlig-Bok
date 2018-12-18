#!/usr/bin/env node

const homedir = require('os').homedir();
const CDP = require(homedir+'/.config/yarn/global/node_modules/chrome-remote-interface/');
const fs = require('fs');

const port = process.argv[2];
const htmlFilePath = process.argv[3];
const pdfFilePath = process.argv[4];

(async function() {

        const protocol = await CDP({port: port});

        // Extract the DevTools protocol domains we need and enable them.
        // See API docs: https://chromedevtools.github.io/devtools-protocol/
        const {Page} = protocol;
        await Page.enable();

        Page.loadEventFired(function () {
                console.log("Waiting 100ms just to be sure.")
                setTimeout(function () {
                        //https://chromedevtools.github.io/devtools-protocol/tot/Page/#method-printToPDF
                        console.log("Printing...")
                        Page.printToPDF({
                                displayHeaderFooter: false,
                                headerTemplate: '<div></div>',
                                //footerTemplate: '<div></div>',
                                footerTemplate: '<div class="text center"><span class="url"></span></div>',
                                //footerTemplate: '<div class="text center"><span class="pageNumber"></span> of <span class="totalPages"></span></div>'
                        }).then((base64EncodedPdf) => {
                                fs.writeFileSync(pdfFilePath, Buffer.from(base64EncodedPdf.data, 'base64'), 'utf8');
                                console.log("Done")
                                protocol.close();
                        });
                }, 100);
        });

//        Page.navigate({url: 'file://'+htmlFilePath});
        Page.navigate({url: htmlFilePath});
})();
