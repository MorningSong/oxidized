class MLNXOS < Oxidized::Model
  using Refinements

  prompt /^\r?\S* \[\S+: (master|standby)\] [#>] $/
  comment '## '
  clean :escape_codes

  # Pager Handling
  # "Normal" pager: "lines 183-204 "
  # Last pager:     "lines 256-269/269 (END) "
  expect /lines \d+-\d+( |\/\d+ \(END\) )/ do |data, re|
    send ' '
    data.sub re, ''
  end

  cmd :all do |cfg|
    cfg.gsub! /.\x08/, '' # Remove Backspace char
    cfg.gsub! /^CPU load averages:\s.+/, '' # Omit constantly changing CPU info
    cfg.gsub! /^System memory:\s.+/, '' # Omit constantly changing memory info
    cfg.gsub! /^Uptime:\s.+/, '' # Omit constantly changing uptime info
    cfg.gsub! /.+Generated at\s\d+.+/, '' # Omit constantly changing generation time info
    cfg.lines.to_a[2..-3].join
  end

  cmd :secret do |cfg|
    cfg.gsub! /(snmp-server community).*/, '   <snmp-server community configuration removed>'
    cfg.gsub! /username (\S+) password (\d+) (\S+).*/, '<secret hidden>'
    cfg
  end

  cmd 'show version' do |cfg|
    comment cfg
  end

  cmd 'show inventory' do |cfg|
    comment cfg
  end

  cmd 'enable'

  cmd 'show running-config' do |cfg|
    cfg
  end

  cfg :ssh do
    password /^Password:\s*/
    post_login 'no cli session paging enable'
    pre_logout "\nexit"
  end
end
