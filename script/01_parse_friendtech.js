// Usage: node 01_parse_friendtech.js <input_file> <output_file>
const fs = require('fs');

if (process.argv.length < 4) {
    console.log('Usage: node 01_parse_friendtech.js <input_file> <output_file>');
    process.exit(1);
}

const inputFilename = process.argv[2];
const outputFilename = process.argv[3];

fs.readFile(inputFilename, 'utf8', (err, data) => {
    if (err) {
        console.error('Error reading the file:', err);
        return;
    }

    const jsonData = JSON.parse(data);

    // Filter the data to ensure valid entries
    const validData = jsonData.filter(obj => {
        return obj.address && obj.twitterPfpUrl && obj.twitterPfpUrl.startsWith("https://pbs.twimg.com/");
    });

    if (validData.length < 64) {
        console.error('There are not at least 64 valid objects in the JSON file.');
        return;
    }

    const seedOrder = [0, 14, 10, 6, 2, 8, 12, 4, 5, 13, 9, 3, 7, 11, 15, 1]

    let bracket = new Array(64);

    // Seed bracket properly.
    for (let i = 0; i < seedOrder.length; i++) {
      for (let j = 0; j < 4; j ++) {
        bracket[j * 16 + seedOrder[i]] = validData[4 * i + j];
      }
    }

    // Map valid data to desired output format
    const addresses = bracket.slice(0, 64).map(obj => BigInt(obj.address));
    const serializedIDs = '[' + addresses.join(",") + ']';

    const uris = bracket.slice(0, 64).map(obj => `https://prod-api.kosetto.com/users/${obj.address}`);
    const serializedURIs = '[' + uris.map(uri => `"${uri}"`).join(",") + ']';
    
    const outputData = '{"ids":' + serializedIDs + ',"uris":' + serializedURIs + '}';

    fs.writeFile(outputFilename, outputData, 'utf8', err => {
        if (err) {
            console.error('Error writing the file:', err);
            return;
        }

        console.log(`Output has been written to ${outputFilename}`);
    });
});
