import { FileBlob, SpreadsheetFile } from "@oai/artifact-tool";

const sourcePath = new URL("./2026-city-tax-rate-workbook.xlsx", import.meta.url).pathname.replace(/^\/(.:)/, "$1");
const input = await FileBlob.load(sourcePath);
const workbook = await SpreadsheetFile.importXlsx(input);

const summary = await workbook.inspect({
  kind: "workbook,sheet,table",
  maxChars: 12000,
  tableMaxRows: 12,
  tableMaxCols: 16,
  tableMaxCellChars: 120,
});

process.stdout.write(summary.ndjson);
