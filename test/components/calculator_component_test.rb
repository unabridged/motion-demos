require "test_helper"

class CalculatorComponentTest < ViewComponent::TestCase
  include Motion::TestHelpers
  let(:klass) { CalculatorComponent }
  let(:total) { 0 }
  subject { klass.new(total: total) }

  describe "rendering" do
    before { render_inline(subject).to_html }

    describe "when total is zero" do
      it "shows buffer-area with current value" do
        assert_selector ".buffer", {count: 1, text: "0"}
      end
    end

    describe "when total is some other value" do
      let(:total) { 30 }
      it "shows buffer-area with current value" do
        assert_selector ".buffer", {count: 1, text: "30"}
      end
    end

    it "renders buttons for every number 0-10 plus a period" do
      assert_selector "button.number-btn[data-motion=\"add_char\"]", {count: 11}
    end

    it "renders buttons for all operations: +, -, *, /" do
      assert_selector "button.op-btn[data-motion=\"operation\"]", {count: 4}
    end

    it "renders percent button" do
      assert_selector "button[data-motion=\"percent\"]", {text: "%"}
    end

    it "renders clear button" do
      assert_selector "button[data-motion=\"clear\"]", {text: "C"}
    end

    it "renders change sign button" do
      assert_selector "button[data-motion=\"change_sign\"]", {text: "+/-"}
    end
  end

  describe "motions" do
    describe "#add_char" do
      let(:selected_value) { "7" }
      let(:dot_params) { {target: {attributes: {"data-char" => "."}}} }
      let(:params) { {target: {attributes: {"data-char" => selected_value}}} }
      let(:num) { 3 }
      let(:num_value) { selected_value * num }
      let(:event) { motion_event(params) }
      let(:motion) { :add_char }

      it "updates current_value by selected" do
        assert_changes -> { subject.current_value }, from: "0", to: selected_value do
          run_motion(subject, motion, event)
        end
      end

      it "appends to the string by selected" do
        assert_changes -> { subject.current_value }, from: "0", to: num_value do
          num.times { run_motion(subject, motion, event) }
        end
      end

      it "allows the creation of decimal point numbers" do
        assert_changes -> { subject.current_value }, from: "0", to: "#{num_value}.#{num_value}" do
          num.times { run_motion(subject, motion, event) }
          run_motion(subject, motion, motion_event(dot_params))
          num.times { run_motion(subject, motion, event) }
        end
      end
    end

    describe "#operation" do
      let(:motion) { :operation }
      let(:op) { %w[+ - * /].sample }
      let(:params) { {target: {attributes: {"data-op" => op}}} }
      let(:event) { motion_event(params) }
      let(:buffer) { "7" }
      let(:operand_one) { 21 }
      let(:init_op) { (%w[+ - * /] + [nil]).sample }
      before do
        subject.instance_variable_set("@op", init_op)
        subject.instance_variable_set("@operand_one", operand_one)
        subject.instance_variable_set("@buffer", buffer)
      end

      describe "when buffer is blank" do
        # Scenario when user has typed in one number (stored in operand_one) and an operation
        # and calculator is ready to accept another number but user types in operation again
        # instead, in effect changing which operation will be run on the current set of numbers
        let(:buffer) { "" }
        it "doesn't change value" do
          assert_no_changes -> { subject.current_value.to_s } do
            run_motion(subject, motion, event)
          end
        end

        it "sets op" do
          assert_changes -> { subject.op }, from: init_op, to: op.to_sym do
            run_motion(subject, motion, event)
          end
        end
      end

      describe "when buffer is set" do
        let(:operand_one) { [21, nil].sample }

        it "sets op" do
          assert_changes -> { subject.op }, from: init_op, to: op.to_sym do
            run_motion(subject, motion, event)
          end
        end

        it "resets buffer" do
          assert_changes -> { subject.buffer }, from: buffer, to: "" do
            run_motion(subject, motion, event)
          end
        end

        describe "when operand is blank" do
          # Scenario when user was typing in first number and now types in an operation and should
          # be able to start typing another number afterwards
          let(:operand_one) { nil }
          it "doesn't change value" do
            assert_no_changes -> { subject.current_value.to_s } do
              run_motion(subject, motion, event)
            end
          end
        end

        describe "when operand is set" do
          let(:operand_one) { 21 }
          let(:init_op) { %w[+ - * /].sample }
          let(:after_operation) { operand_one.send(init_op, buffer.to_f) }

          # Scenario when user typed in two numbers (stored in buffer & operand_one),
          # but they have not been calculated yet, and instead of hitting equals,
          # the user typed another operation, so we need to calculate the previous operation
          # and free up buffer for them to type in a third number
          it "performs operation using int_op" do
            assert_changes -> { subject.current_value.to_f },
              from: buffer.to_f, to: after_operation do
              run_motion(subject, motion, event)
            end
          end
        end
      end
    end

    describe "#equals" do
      let(:motion) { :equals }
      let(:op) { %w[+ - * /].sample }
      let(:params) { {target: {attributes: {"data-op" => op}}} }
      let(:event) { motion_event(params) }
      let(:buffer) { "7" }
      let(:operand_one) { 21 }
      before do
        subject.instance_variable_set("@op", op)
        subject.instance_variable_set("@operand_one", operand_one)
        subject.instance_variable_set("@buffer", buffer)
      end

      describe "when buffer is blank" do
        let(:buffer) { "" }
        let(:operand_one) { [21, nil].sample }
        it "doesn't change value" do
          assert_no_changes -> { subject.current_value.to_s } do
            run_motion(subject, motion, event)
          end
        end

        it "no changes to op" do
          assert_no_changes -> { subject.op } do
            run_motion(subject, motion, event)
          end
        end

        describe "when operand_one is set" do
          let(:operand_one) { 21 }
          # Scenario when user has typed in one number (stored in operand_one) and an operation
          # and calculator is ready to accept another number but user types in equals
          it "allows user to press equals, continue typing in a number, and then equals again" do
            new_num = "3"
            new_value = operand_one.send(op, new_num.to_f)
            add_char_params = {target: {attributes: {"data-char" => new_num}}}
            assert_changes -> { subject.current_value.to_f }, from: operand_one.to_f, to: new_value.to_f do
              run_motion(subject, motion, event)
              run_motion(subject, :add_char, motion_event(add_char_params))
              run_motion(subject, motion, event)
            end
          end
        end

        describe "when operand_one is blank" do
          let(:operand_one) { nil }
          # Scenario when user has not typed in second number but has typed equals
          it "allows user to press equals and then type in numbers and operations and will work" do
            new_num = "3"
            new_value = new_num.to_i.send(op, new_num.to_i)
            add_char_params = {target: {attributes: {"data-char" => new_num}}}
            add_op_params = {target: {attributes: {"data-op" => op}}}
            assert_changes -> { subject.current_value.to_s }, from: operand_one.to_s, to: new_value.to_s do
              run_motion(subject, motion, event)
              run_motion(subject, :add_char, motion_event(add_char_params))
              run_motion(subject, :operation, motion_event(add_op_params))
              run_motion(subject, :add_char, motion_event(add_char_params))
              run_motion(subject, motion, event)
            end
          end
        end
      end

      describe "when buffer is set" do
        let(:operand_one) { [21, nil].sample }

        it "change op to nil" do
          assert_changes -> { subject.op }, from: op, to: nil do
            run_motion(subject, motion, event)
          end
        end

        it "resets buffer" do
          assert_changes -> { subject.buffer }, from: buffer, to: "" do
            run_motion(subject, motion, event)
          end
        end

        describe "when operand is blank" do
          # Scenario when user was typing in first number but not second number and an equal sign
          let(:operand_one) { nil }
          it "doesn't change value" do
            assert_no_changes -> { subject.current_value.to_s } do
              run_motion(subject, motion, event)
            end
          end
        end

        describe "when operand is set" do
          let(:operand_one) { 21 }
          let(:after_operation) { operand_one.send(op, buffer.to_f) }

          # Scenario when user typed in two numbers, an operation, and pressed equals
          it "performs operation using op" do
            assert_changes -> { subject.current_value.to_f },
              from: buffer.to_f, to: after_operation do
              run_motion(subject, motion, event)
            end
          end
        end
      end
    end

    describe "#percent" do
      let(:motion) { :percent }
      let(:op) { %w[+ - * /].sample }
      let(:buffer) { ["7", ""].sample }
      let(:operand_one) { [21, nil].sample }
      let(:current_value) { buffer.blank? ? operand_one : buffer }
      let(:percent) { current_value.to_f / 100.0 }
      before do
        subject.instance_variable_set("@op", op)
        subject.instance_variable_set("@operand_one", operand_one)
        subject.instance_variable_set("@buffer", buffer)
      end

      it "no changes to op" do
        assert_no_changes -> { subject.op } do
          run_motion(subject, motion)
        end
      end

      describe "when both are zero" do
        let(:buffer) { "" }
        let(:operand_one) { nil }

        it "no change in value percent" do
          assert_no_changes -> { subject.current_value.to_f }, from: "0".to_f do
            run_motion(subject, motion)
          end
        end
      end

      describe "when at least one is nonzero" do
        let(:config) { [["", 21], ["7", nil], ["7", 21]].sample }
        let(:buffer) { config.first }
        let(:operand_one) { config.second }

        it "changes value by percent" do
          assert_changes -> { subject.current_value.to_f }, from: current_value.to_f, to: percent.to_f do
            run_motion(subject, motion)
          end
        end
      end

      describe "when percent is used and calculations made afterwards" do
        let(:buffer) { "7" }
        let(:operand_one) { 21 }
        let(:new_num) { "3" }
        let(:add_char_params) { {target: {attributes: {"data-char" => new_num}}} }
        let(:add_op_params) { {target: {attributes: {"data-op" => op}}} }

        describe "when buffer is set or operand is set" do
          let(:config) { [["", 21], ["7", nil]].sample }
          let(:buffer) { config.first }
          let(:operand_one) { config.second }
          let(:final_value) { percent.to_f.send(op, new_num.to_f) }

          it "allows user to press +/- and then type in numbers and operations and will work" do
            assert_changes -> { subject.current_value.to_f }, from: current_value.to_f, to: final_value.to_f do
              run_motion(subject, motion)
              run_motion(subject, :operation, motion_event(add_op_params))
              run_motion(subject, :add_char, motion_event(add_char_params))
              run_motion(subject, :operation, motion_event(add_op_params))
            end
          end
        end

        describe "when buffer and operand are set" do
          let(:val_after_first_char) { operand_one.to_f.send(op, percent.to_f) }
          let(:final_value) { val_after_first_char.send(op, new_num.to_f) }

          it "allows user to press +/- and then type in numbers and operations and will work" do
            assert_changes -> { subject.current_value.to_f }, from: current_value.to_f, to: final_value.to_f do
              run_motion(subject, motion)
              run_motion(subject, :operation, motion_event(add_op_params))
              run_motion(subject, :add_char, motion_event(add_char_params))
              run_motion(subject, :operation, motion_event(add_op_params))
            end
          end
        end
      end
    end

    describe "#change_sign" do
      let(:motion) { :change_sign }
      let(:op) { %w[+ - * /].sample }
      let(:buffer) { ["7", ""].sample }
      let(:operand_one) { [21, nil].sample }
      let(:current_value) { buffer.blank? ? operand_one : buffer }
      let(:change_sign) { current_value.to_f * -1 }
      before do
        subject.instance_variable_set("@op", op)
        subject.instance_variable_set("@operand_one", operand_one)
        subject.instance_variable_set("@buffer", buffer)
      end

      it "no changes to op" do
        assert_no_changes -> { subject.op } do
          run_motion(subject, motion)
        end
      end

      describe "when both are zero" do
        let(:buffer) { "" }
        let(:operand_one) { nil }

        it "no change in value" do
          assert_no_changes -> { subject.current_value.to_f }, from: "0".to_f do
            run_motion(subject, motion)
          end
        end
      end

      describe "when at least one is nonzero" do
        let(:config) { [["", 21], ["7", nil], ["7", 21]].sample }
        let(:buffer) { config.first }
        let(:operand_one) { config.second }

        it "changes value by sign" do
          assert_changes -> { subject.current_value.to_f }, from: current_value.to_f, to: change_sign.to_f do
            run_motion(subject, motion)
          end
        end

        it "changes no value if run as multiple of two" do
          assert_no_changes -> { subject.current_value.to_f } do
            6.times { run_motion(subject, motion) }
          end
        end

        it "changes no value if run as mod 1 of 2" do
          assert_changes -> { subject.current_value.to_f }, from: current_value.to_f, to: change_sign.to_f do
            5.times { run_motion(subject, motion) }
          end
        end
      end

      describe "when +/- is used and calculations made afterwards" do
        let(:buffer) { "7" }
        let(:operand_one) { 21 }
        let(:new_num) { "3" }
        let(:add_char_params) { {target: {attributes: {"data-char" => new_num}}} }
        let(:add_op_params) { {target: {attributes: {"data-op" => op}}} }

        describe "when buffer is set or operand is set" do
          let(:config) { [["", 21], ["7", nil]].sample }
          let(:buffer) { config.first }
          let(:operand_one) { config.second }
          let(:final_value) { change_sign.to_f.send(op, new_num.to_f) }

          it "allows user to press +/- and then type in numbers and operations and will work" do
            assert_changes -> { subject.current_value.to_f }, from: current_value.to_f, to: final_value.to_f do
              run_motion(subject, motion)
              run_motion(subject, :operation, motion_event(add_op_params))
              run_motion(subject, :add_char, motion_event(add_char_params))
              run_motion(subject, :operation, motion_event(add_op_params))
            end
          end
        end

        describe "when buffer and operand are set" do
          let(:val_after_first_char) { operand_one.to_f.send(op, change_sign.to_f) }
          let(:final_value) { val_after_first_char.send(op, new_num.to_f) }

          it "allows user to press +/- and then type in numbers and operations and will work" do
            assert_changes -> { subject.current_value.to_f }, from: current_value.to_f, to: final_value.to_f do
              run_motion(subject, motion)
              run_motion(subject, :operation, motion_event(add_op_params))
              run_motion(subject, :add_char, motion_event(add_char_params))
              run_motion(subject, :operation, motion_event(add_op_params))
            end
          end
        end
      end
    end

    describe "#clear" do
      let(:motion) { :clear }
      let(:op) { %w[+ - * /].sample }
      let(:buffer) { "7" }
      let(:operand_one) { 21 }

      before do
        subject.instance_variable_set("@op", op)
        subject.instance_variable_set("@operand_one", operand_one)
        subject.instance_variable_set("@buffer", buffer)
      end

      it "resets op" do
        assert_changes -> { subject.op }, from: op, to: nil do
          run_motion(subject, motion)
        end
      end

      it "resets current_value" do
        assert_changes -> { subject.current_value }, from: buffer, to: nil do
          run_motion(subject, motion)
        end
      end
    end
  end
end
