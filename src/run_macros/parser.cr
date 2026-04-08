require "json"
require "yaml"
require "wordsmith"

CONTENT_REGEX    = /\A(?:-{3}\n(?<frontmatter>.*?)\n-{3}\n)?(?<body>.*)\z/m
ASSET_EXTENSIONS = %w[.avif .gif .jpeg .jpg .mp3 .mp4 .ogg .pdf .png .svg .webm .webp]

alias EntryHash = Hash(String, Array(String) | Bool | Float64 | Hash(String, String) | Int32 | String | Time)

def parse_content(filename : String) : Regex::MatchData
  File.read(filename).match(CONTENT_REGEX) ||
    raise(%(Unable to parse file content))
end

def parse_frontmatter(entry : EntryHash, match : Regex::MatchData) : Nil
  if frontmatter = match["frontmatter"]?
    YAML.parse(frontmatter).as_h.each do |k, v|
      entry[k.as_s] =
        case v.raw
        when Bool    then v.as_bool
        when Int64   then v.as_i
        when Float64 then v.as_f
        when String  then v.as_s
        when Time    then v.as_time
        when Array   then v.as_a.map(&.as_s)
        else              raise %(Unknown frontmatter data type "#{v.class}")
        end
    end
  end
end

def collect_assets(entry : EntryHash, asset_dir : String) : Nil
  return unless Dir.exists?(asset_dir)

  assets = {} of String => String
  Dir.children(asset_dir).sort.each do |child|
    next if child.starts_with?('.')
    next unless ASSET_EXTENSIONS.includes?(File.extname(child).downcase)
    next if File.directory?(child_path = File.join(asset_dir, child))

    assets[child] = child_path.lchop("./")
  end
  entry["assets"] = assets unless assets.empty?
end

begin
  date_regex = /^(?<date>\d{8})_(?<name>[^.]+)/

  path = ARGV[0]? || raise "Missing data path argument"

  # Parse index
  index = nil
  index_file = "./#{path}/_index.md"
  if File.exists?(index_file)
    content_match = parse_content(index_file)
    index = EntryHash.new
    index["content"] = content_match["body"].strip
    parse_frontmatter(index, content_match)
    collect_assets(index, "./#{path}/_index")
  end

  # Parse entries
  entries = Dir.glob("./#{path}/*.md").reject(&.ends_with?("/_index.md")).map do |filename|
    filename_match = File.basename(filename).match(date_regex) ||
                     raise(%(Invalid filename: "#{filename}"))

    content_match = parse_content(filename)

    entry = EntryHash.new
    file = filename_match["name"].to_s
    entry["slug"] = Wordsmith::Inflector.parameterize(file.gsub("_", "-"))
    entry["title"] = Wordsmith::Inflector.humanize(file)
    entry["date"] = Time.parse_local(filename_match["date"], "%Y%m%d")
    entry["source"] = filename
    entry["content"] = content_match["body"].strip

    parse_frontmatter(entry, content_match)
    collect_assets(entry, filename.chomp(".md"))

    entry
  end

  puts (index || {} of String => String).to_json
  puts entries.to_json
rescue ex
  puts ex
end
