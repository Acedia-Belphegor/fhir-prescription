cd `dirname $0`

ruby -r base64 -e 'p Base64.encode64(File.read("example_prescription.xml", encoding: "utf-8"))' | pbcopy
