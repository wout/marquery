require "json"
require "yaml"
require "wordsmith"

begin
  date_regex = /^(?<date>\d{8})_(?<name>[^.]+)/
  content_regex = /\A(?:-{3}\n(?<frontmatter>.*?)\n-{3}\n)?(?<body>.*)\z/m
  asset_extensions = %w[.avif .gif .jpeg .jpg .mp3 .mp4 .ogg .pdf .png .svg .webm .webp]

  path = ARGV[0]? || raise "Missing data path argument"
  entries = Dir.glob("./#{path}/*.md").map do |filename|
    filename_match = File.basename(filename).match(date_regex) ||
                     raise(%(Invalid filename: "#{filename}"))

    content_match = File.read(filename).match(content_regex) ||
                    raise(%(Unable to parse file content))

    # Add base properties
    entry = {} of String => Array(String) | Bool | Float64 | Hash(String, String) | Int32 | String | Time
    file = filename_match["name"].to_s
    entry["slug"] = Wordsmith::Inflector.parameterize(file.gsub("_", "-"))
    entry["title"] = Wordsmith::Inflector.humanize(file)
    entry["date"] = Time.parse_local(filename_match["date"], "%Y%m%d")
    entry["source"] = filename
    entry["content"] = content_match["body"].strip

    # Add any frontmatter properties
    if frontmatter = content_match["frontmatter"]?
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

    # Collect assets
    if Dir.exists?(asset_dir = filename.chomp(".md"))
      assets = {} of String => String
      Dir.children(asset_dir).sort.each do |child|
        next if child.starts_with?('.')
        next unless asset_extensions.includes?(File.extname(child).downcase)
        next if File.directory?(child_path = File.join(asset_dir, child))

        assets[child] = child_path.lchop("./")
      end
      entry["assets"] = assets unless assets.empty?
    end

    entry
  end

  puts entries.to_json
rescue ex
  puts ex
end
