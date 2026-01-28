const crypto = require('crypto');
const fs = require('fs');

function generateClientSecret(keyFile, teamId, clientId, keyId) {
    const privateKey = fs.readFileSync(keyFile, 'utf8');

    const header = {
        alg: 'ES256',
        kid: keyId,
        typ: 'JWT'
    };

    const now = Math.floor(Date.now() / 1000);
    const payload = {
        iss: teamId,
        iat: now,
        exp: now + 15777000, // 6 months
        aud: 'https://appleid.apple.com',
        sub: clientId
    };

    const base64UrlEncode = (str) => {
        return Buffer.from(JSON.stringify(str))
            .toString('base64')
            .replace(/\+/g, '-')
            .replace(/\//g, '_')
            .replace(/=/g, '');
    };

    const encodedHeader = base64UrlEncode(header);
    const encodedPayload = base64UrlEncode(payload);

    const data = `${encodedHeader}.${encodedPayload}`;
    const signer = crypto.createSign('RSA-SHA256'); // Wait, ES256 is ECDSA with P-256 and SHA-256

    // Correct way for ES256 in Node crypto:
    const sign = crypto.sign("sha256", Buffer.from(data), {
        key: privateKey,
        dsaEncoding: 'ieee-p1363'
    }).toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');

    return `${data}.${sign}`;
}

const TEAM_ID = "KXVAN4J7F3";
const CLIENT_ID = "com.yuna.yoga.bauti"; // Use Bundle ID for mobile apps
const KEY_ID = "CYMA73GRPV";
const KEY_FILE = "AuthKey_CYMA73GRPV.p8";

try {
    const secret = generateClientSecret(KEY_FILE, TEAM_ID, CLIENT_ID, KEY_ID);
    console.log("\n✅ Generated Client Secret JWT:");
    console.log("--------------------");
    console.log(secret);
    console.log("--------------------");
} catch (e) {
    console.error("\n❌ Error:", e.message);
}
