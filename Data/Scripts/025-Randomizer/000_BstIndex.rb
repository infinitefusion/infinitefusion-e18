class BstIndex
  # entries: [bst, species, legendary?] sorted by bst
  def initialize(entries)
    @bsts    = entries.map { |e| e[0] }
    @species = entries.map { |e| e[1] }
  end

  def empty?
    @species.empty?
  end

  def sample_any
    @species.sample
  end

  def sample_in_range(lo, hi)
    first = @bsts.bsearch_index { |b| b >= lo }
    return nil if first.nil?
    last = @bsts.bsearch_index { |b| b > hi } || @bsts.length
    return nil if last <= first
    @species[first + rand(last - first)]
  end
end

class SpeciesPools
  attr_reader :all, :legendary, :normal

  def initialize(species_list)
    entries = species_list.map { |sp| [calcBaseStatsSum(sp), sp, is_legendary(sp)] }
    entries.sort_by! { |e| e[0] }
    @all       = BstIndex.new(entries)
    @legendary = BstIndex.new(entries.select { |e| e[2] })
    @normal    = BstIndex.new(entries.reject { |e| e[2] })
  end
end