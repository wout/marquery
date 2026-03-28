require "json"
require "yaml"
require "wordsmith"

begin
  date_regex = /^(?<date>\d{8})_(?<name>[^.]+)/
  content_regex = /\A(?:-{3}\n(?<frontmatter>.*?)\n-{3}\n)?(?<body>.*)\z/m

  path = ARGV[0]? || raise "Missing data path argument"
  entries = Dir.glob("./data/#{path}/*.md").map do |filename|
    filename_match = File.basename(filename).match(date_regex) ||
                     raise(%(Invalid filename: "#{filename}"))

    content_match = File.read(filename).match(content_regex) ||
                    raise(%(Unable to parse file content))

    entry = {} of String => Bool | Float64 | Int32 | String | Time
    entry["slug"] = Wordsmith::Inflector.parameterize(filename_match["name"].to_s.gsub("_", "-"))
    entry["title"] = Wordsmith::Inflector.humanize(filename_match["name"].to_s)
    entry["date"] = Time.parse_local(filename_match["date"], "%Y%m%d")
    entry["content"] = content_match["body"].strip

    if frontmatter = content_match["frontmatter"]?
      YAML.parse(frontmatter).as_h.each do |k, v|
        entry[k.as_s] =
          v.as_bool? || v.as_i? || v.as_f? || v.as_s? || v.as_time? ||
            raise %(Unknown frontmatter data type "#{v.class}")
      end
    end

    entry
  end

  puts entries.to_json
rescue ex
  puts ex
end
