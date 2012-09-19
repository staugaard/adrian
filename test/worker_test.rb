require_relative 'test_helper'

describe Adrian::Worker do
  describe "#perform" do
    before { @item = 2}

    it "should report back to the boss" do
      worker_class = Class.new(Adrian::Worker) do
        def work; item + 2; end
      end

      worker = worker_class.new(@item)
      boss = MiniTest::Mock.new
      worker.report_to(boss)

      boss.expect(:work_done, nil, [@item, nil])
      worker.perform

      boss.verify
    end

    it "should NEVER raise an exception" do
      worker_class = Class.new(Adrian::Worker) do
        def work; raise "STRIKE!"; end
      end

      worker = worker_class.new(@item)
      boss = MiniTest::Mock.new
      worker.report_to(boss)

      boss.expect(:work_done, nil, [@item, RuntimeError])

      worker.perform

      boss.verify
    end
  end
end
