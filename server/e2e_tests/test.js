import { launch } from 'chrome-launcher';
import sleep from 'sleep-promise'
import CDP from 'chrome-remote-interface';
import assert from 'assert';

(async function () {
    async function launchChrome() {
        return await launch({
            chromeFlags: [
                '--disable-gpu',
                '--headless'
            ]
        });
    }
    const chrome = await launchChrome();
    const protocol = await CDP({
        port: chrome.port
    });

    const { Network, Page, Runtime } = protocol;
    await Page.enable();
    await Page.navigate({ url: 'http://localhost:3000/' });
    const full_flow = `await new Promise(r => setTimeout(r, 2000));;document.querySelector('#accountInput').value = 'tt';
    document.querySelector('#accountSubmit').click();
    document.querySelector('#accountList').outerHTML;`
    const login_flow = `document.querySelector('#passwordInput').value = 'abc';
    document.querySelector('#passwordSubmit').click();`

    const check_flow = `document.querySelector('#permissions').outerHTML;`

    Page.loadEventFired(async () => {
        const result = await Runtime.evaluate({
            expression: login_flow + full_flow
        });

        console.log(result)
    });

    Page.loadEventFired(async () => {
        const result = await Runtime.evaluate({
            expression: full_flow
        });

        console.log(result)
    });
    await sleep(100);
    Page.loadEventFired(async () => {
        const result = await Runtime.evaluate({
            expression: check_flow
        });

        console.log(result)
    });
    // Test something about the page after you've logged in here
})();