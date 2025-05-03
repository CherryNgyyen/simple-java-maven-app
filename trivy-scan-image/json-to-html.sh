#!/bin/sh

INPUT_JSON="$1"
OUTPUT_HTML="$2"

if [ -z "$INPUT_JSON" ] || [ ! -f "$INPUT_JSON" ]; then
    echo "Usage: $0 <input-json> <output-html>"
    exit 1
fi

cat <<EOF > "$OUTPUT_HTML"
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Trivy Scan Report</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    table { border-collapse: collapse; width: 100%; margin-top: 20px; }
    th, td { border: 1px solid #ddd; padding: 8px; }
    th { background-color: #f2f2f2; }
    tr:hover { background-color: #f9f9f9; }
    .critical { color: red; font-weight: bold; }
    .high { color: orange; font-weight: bold; }
  </style>
</head>
<body>
  <h1>Trivy Scan Report</h1>
  <table>
    <thead>
      <tr>
        <th>Target</th>
        <th>Package</th>
        <th>Vulnerability ID</th>
        <th>Severity</th>
        <th>Title</th>
        <th>Installed Version</th>
        <th>Fixed Version</th>
      </tr>
    </thead>
    <tbody>
EOF

jq -r '.Results[] | select(.Vulnerabilities != null) | .Target as $target | .Vulnerabilities[] |
    "<tr><td>" + $target + "</td><td>" + .PkgName + "</td><td>" + .VulnerabilityID + "</td><td><span class=\"" + (.Severity | ascii_downcase) + "\">" + .Severity + "</span></td><td>" + (.Title // "-") + "</td><td>" + .InstalledVersion + "</td><td>" + (.FixedVersion // "-") + "</td></tr>"' "$INPUT_JSON" >> "$OUTPUT_HTML"

cat <<EOF >> "$OUTPUT_HTML"
    </tbody>
  </table>
</body>
</html>
EOF

echo "HTML report generated at: $OUTPUT_HTML"
