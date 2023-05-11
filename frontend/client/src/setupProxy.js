const { createProxyMiddleware } = require('http-proxy-middleware');

module.exports = function (app) {
    app.use(
        createProxyMiddleware('/interpret', {
            target: 'http://localhost:3001/interpret', // API endpoint 1
            changeOrigin: true,
            pathRewrite: {
                "^/interpret": "",
            },
            headers: {
                Connection: "keep-alive"
            }
        })
    );
    app.use(
        createProxyMiddleware('/check', {
            target: 'http://localhost:3003/check', // API endpoint 2
            changeOrigin: true,
            pathRewrite: {
                "^/check": "",
            },
            headers: {
                Connection: "keep-alive"
            }
        })
    );
}
// const proxy = require('http-proxy-middleware');
// module.exports = function (app) {
//     app.use(proxy('/intepret', { target: 'http://localhost:3001/interpret' })),
//         app.use(proxy('/check', { target: 'http://localhost:3003/check' }))
// }