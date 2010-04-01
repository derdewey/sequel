# The pretty_table extension adds Sequel::Dataset#print and the
# Sequel::PrettyTable class for creating nice-looking plain-text
# tables.

module Sequel
  class Dataset
    # Pretty prints the records in the dataset as plain-text table.
    def print(*cols)
      Sequel::PrettyTable.print(naked.all, cols.empty? ? columns : cols)
    end
    def print_to_string(*cols)
      Sequel::PrettyTable.print_to_string(naked.all, cols.empty? ? columns : cols)
    end
  end

  module PrettyTable
    def self.print_to_string(records, columns = nil)
      table = ""
      columns ||= records.first.keys.sort_by{|x|x.to_s}
      sizes = column_sizes(records, columns)
      sep_line = separator_line(columns, sizes)

      table << sep_line
      table << header_line(columns, sizes)
      table << sep_line
      records.each {|r| table << data_line(columns, sizes, r)}
      table << sep_line
    end
  
    # Prints nice-looking plain-text tables via puts
    # 
    #   +--+-------+
    #   |id|name   |
    #   |--+-------|
    #   |1 |fasdfas|
    #   |2 |test   |
    #   +--+-------+
    def self.print(records, columns = nil) # records is an array of hashes
      puts print_to_string(records, columns)
    end

    ### Private Module Methods ###

    # Hash of the maximum size of the value for each column 
    def self.column_sizes(records, columns) # :nodoc:
      sizes = Hash.new {0}
      columns.each do |c|
        s = c.to_s.size
        sizes[c.to_sym] = s if s > sizes[c.to_sym]
      end
      records.each do |r|
        columns.each do |c|
          s = r[c].to_s.size
          sizes[c.to_sym] = s if s > sizes[c.to_sym]
        end
      end
      sizes
    end
    
    # String for each data line
    def self.data_line(columns, sizes, record) # :nodoc:
      '|' << columns.map {|c| format_cell(sizes[c], record[c])}.join('|') << '|'
    end
    
    # Format the value so it takes up exactly size characters
    def self.format_cell(size, v) # :nodoc:
      case v
      when Bignum, Fixnum
        "%#{size}d" % v
      when Float
        "%#{size}g" % v
      else
        "%-#{size}s" % v.to_s
      end
    end
    
    # String for header line
    def self.header_line(columns, sizes) # :nodoc:
      '|' << columns.map {|c| "%-#{sizes[c]}s" % c.to_s}.join('|') << '|'
    end

    # String for separtor line
    def self.separator_line(columns, sizes) # :nodoc:
      '+' << columns.map {|c| '-' * sizes[c]}.join('+') << '+'
    end

    private_class_method :column_sizes, :data_line, :format_cell, :header_line, :separator_line
  end
end

