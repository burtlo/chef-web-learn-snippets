module LearnChef
  module ComplianceHelpers

  def has_compliance_data?(key)
    h = node.run_state[COMPLIANCE_DATA_KEY]
    return false unless h
    key.split("/").each do |k|
      return false unless h.has_key?(k)
      h = h[k]
    end
    true
  end

  def get_compliance_data(key)
    h = node.run_state[COMPLIANCE_DATA_KEY]
    key.split("/").each do |k|
      h = h[k]
    end
    h
  end

  def set_compliance_data(key, data)
    if key
      key_path = key.split("/")
      node.run_state[COMPLIANCE_DATA_KEY] = {} unless node.run_state.has_key?(COMPLIANCE_DATA_KEY)

      #node.run_state[COMPLIANCE_DATA_KEY].merge!((key_path + [data]).reverse.reduce { |s,e| { e => s } }) { |k,o,n| o.merge(n) }
      h = node.run_state[COMPLIANCE_DATA_KEY]
      key_path[0..-2].each do |k|
        h[k] = {} unless h.has_key?(k)
        h = h[k]
      end
      h[key_path[-1]] = data

      save_compliance_data
    end
  end

  def save_compliance_data
    ::File.write("/vagrant/#{COMPLIANCE_DATA_KEY}", node.run_state[COMPLIANCE_DATA_KEY].to_s)
  end

  def load_compliance_data
    path = "/vagrant/#{COMPLIANCE_DATA_KEY}"
    if ::File.exist?(path)
      node.run_state[COMPLIANCE_DATA_KEY] = eval(::File.read(path))
    end
  end

  private

  COMPLIANCE_DATA_KEY = 'compliance_api_data'

end; end
