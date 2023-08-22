// Run with node.
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

    // Filter the data to ensure valid entries
    const validData = jsonData.filter(obj => {
        return obj.address && obj.twitterPfpUrl && obj.twitterPfpUrl.startsWith("https://pbs.twimg.com/");
    });

    if (validData.length < 64) {
        console.error('There are not at least 64 valid objects in the JSON file.');
        return;
    }

    // Map valid data to desired output format
    const outputData = validData.slice(0, 64).map(obj => {
        const id = BigInt(obj.address);
        const uri = `https://prod-api.kosetto.com/users/${obj.address}`;
        return { id, uri };
    });

    // Custom serialization for BigInt to number
    const serializedOutput = '[' + outputData.map(item => {
        return `{"id":${item.id},"uri":"${item.uri}"}`;
    }).join(",") + ']';

    fs.writeFile(outputFilename, serializedOutput, 'utf8', err => {
        if (err) {
            console.error('Error writing the file:', err);
            return;
        }

        console.log(`Output has been written to ${outputFilename}`);
    });
});
