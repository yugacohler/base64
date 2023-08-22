const fs = require('fs');

if (process.argv.length < 4) {
    console.log('Usage: node process_json.js <input_file> <output_file>');
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

    if (jsonData.length < 64) {
        console.error('The JSON file does not contain at least 64 objects.');
        return;
    }

    // Convert the address from hex to base-10 representation
    const ids = jsonData.slice(0, 64).map(obj => {
        const bigIntValue = BigInt(obj.address);
        return bigIntValue.toString(10);
    });

    // Generate the URIs
    const uris = jsonData.slice(0, 64).map(obj => `https://prod-api.kosetto.com/users/${obj.address}`);

    // Construct the output string
    const outputString = `[${ids.join(",")}] [${uris.join(",")}]`;

    fs.writeFile(outputFilename, outputString, 'utf8', err => {
        if (err) {
            console.error('Error writing the file:', err);
            return;
        }

        console.log(`Output has been written to ${outputFilename}`);
    });
});
