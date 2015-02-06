require 'helper'
require 'bio'
require 'tmpdir'

class TestAssembly < Test::Unit::TestCase

  context "Assembly" do

    setup do
      a = File.join(File.dirname(__FILE__), 'data', 'sorghum_100.fa')
      @assembly = Transrate::Assembly.new(a)
    end

    should "run" do
      @assembly.run 1
      assert_equal true, @assembly.has_run
    end

    should "classify contigs" do
      @assembly.run 1
      read_metrics = Transrate::ReadMetrics.new(@assembly)
      left = File.join(File.dirname(__FILE__), 'data', 'sorghum_100.1.fastq')
      right = File.join(File.dirname(__FILE__), 'data', 'sorghum_100.2.fastq')
      Dir.mktmpdir do |tmpdir|
        Dir.chdir tmpdir do
          read_metrics.run(left, right)
          @assembly.classify_contigs
          assert File.exist?("good.sorghum_100.fa"), "good output exists"
          assert File.exist?("fragmented.sorghum_100.fa"), "fragmented output"
          assert File.exist?("chimeric.sorghum_100.fa"), "chimeric output"
          assert File.exist?("bad.sorghum_100.fa"), "bad output"
          file_size = File.stat("good.sorghum_100.fa").size
          assert_in_delta 80_748, file_size, 2000, "good file size"
          file_size = File.stat("bad.sorghum_100.fa").size
          assert_in_delta 53_986, file_size, 2000, "bad file size"
        end
      end
    end

  end
end
