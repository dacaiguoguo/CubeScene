require 'csv'
require 'find'

class Localizer
  attr_reader :dir_path, :languages, :translations

  def initialize(dir_path, languages)
    @dir_path = dir_path
    @languages = languages
    @translations = Hash.new { |h, k| h[k] = [] }
  end

  def process_files
    Find.find(@dir_path) do |path|
      next unless path.end_with?('.csv')
      process_csv(path)
    end
  end

  def process_csv(path)
    CSV.foreach(path, headers: true) do |row|
      row_hash = row.to_h
      row_hash ||= {}
      key_value = row_hash[row_hash.keys.compact.find { |e| e.include?("key") }]
      # Skip rows without a key
      next if key_value.nil? || key_value.strip.empty?
  
      @languages.each do |lang_code, lang_key|
        lang_value = row_hash[lang_key]
        next unless lang_value.is_a?(String)
        lang_value = lang_value.strip.gsub("\"", "'")  # Remove leading/trailing spaces and newlines, and replace double quotes with single quotes
        output = "\"#{key_value.strip}\" = \"#{lang_value}\";"
        @translations[lang_code] << output
      end
    end
  end
  

  def write_files
    @languages.each do |lang_code, _|
      next if @translations[lang_code].empty?
  
      lang_dir = "#{@dir_path}/#{lang_code}.lproj"
      Dir.mkdir(lang_dir) unless Dir.exist?(lang_dir)
      content = @translations[lang_code].sort.join("\n") + "\n"  # 在内容末尾添加换行符
      File.write("#{lang_dir}/Localizable.strings", content)
    end
  end
  
end

languages = {
  'en' => 'English',
  'de' => '德文|de',
  'ru' => '俄语|ru',
  'fr' => '法语|fr',
  'zh-Hans' => '简体中文|zh-Hans',
  'pt-PT' => '葡萄牙语|pt-PT',
  'zh-Hant' => '繁体中文|zh-Hant',
  'zh-HK' => '繁体中文|zh-Hant',
  'ja' => '日语|ja',
  'es' => '西班牙语|es',
  'ko' => '韩语|ko',
  'it' => '意大利文|it',
  'ar' => '阿拉伯语|ar',
  'tr' => '土耳其语|tr',
  'uk' => '乌克兰语|uk',
  'vi' => '越南语|vi',
  'ms' => '马来语|ms',
  'id' => '印尼语|id',
  'th' => '泰语|th',
  'el' => '希腊语|el',
  'cs' => '捷克语|cs',
  'sv' => '瑞典语|sv',
  'he' => '希伯来语|he',
  'hi' => '北印度文/印地文|hi',
  'nl' => '荷兰语|nl'
}
# excel是国际化表格 参考 https://gaoxiang.larksuite.com/sheets/XBGJssbYZh5OrftgASFu64UTs8c?from=from_copylink
# 格式要求：1.必须有key列 
#         2.其他国家的列名按以上languages填写（不要多空格、换行）
# 脚本作用 将excel表格导出为csv格式，然后放在dir_path内
# 执行方法：ruby readall.rb，将会读取csv中数据，解析后输出为
# iOS需要的国际化文件格式
# 例如auth.csv可以提交到git中，做版本记录
# TODO 1.重复key检测，如果有重复的key就报错 2.字符以英文为基准，超过一定数量或者百分比就报错
dir_path = "/Users/yanguosun/Developer/CubeScene/CubeScene/support/localz"
localizer = Localizer.new(dir_path, languages)
localizer.process_files
localizer.write_files
