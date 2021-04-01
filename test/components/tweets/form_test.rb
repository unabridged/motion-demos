# frozen_string_literal: true

require "test_helper"

module Tweets
  # rubocop:disable Metrics/ClassLength
  class FormTest < ViewComponent::TestCase
    include Motion::TestHelpers

    let(:klass) { Tweets::Form }
    let(:tweet) { Tweet.new }

    let(:user) { Fabricate.build(:user, id: 1) }
    let(:date) { nil }
    let(:mode) { "multi" }
    let(:pub1) { Fabricate.build(:publication, id: 3) }
    let(:pub2) { Fabricate.build(:publication, id: 4) }
    let(:october_first) { Date.new(2020, 10, 1) }
    let(:edition_dates) { stub(pluck: edition_date_pairs) }
    let(:edition_date_pairs) do
      [
        [ed_date(Date.current), ed_date(1.month.from_now)],
        [ed_date(1.month.from_now), ed_date(2.months.from_now)],
        [ed_date(2.month.from_now), ed_date(3.months.from_now)],
      ]
    end
    let(:editions) do
      [
        stub(id: 1, publication_id: pub1.id, publication_name: pub1.name,
             deadline_day: 25, total_clients: 100, pages_of_ads: 10.5,
             total_value: 5000, total_amount: 4000, total_unpaid: 0),
        stub(id: 2, publication_id: pub2.id, publication_name: pub2.name,
             deadline_day: 10, total_clients: 50, pages_of_ads: 15.0,
             total_value: 4000, total_amount: 3000, total_unpaid: 100),
      ]
    end
    let(:cross_sales) { [] }
    let(:current_user_id) { 1 }
    let(:config) do
      config_class.new(
        publication_ids: [3, 4], user_id: 1, date: date, title: "Ads Report",
        current_user_id: current_user_id, mode: mode
      )
    end
    subject { klass.new(config) }

    before do
      travel_to october_first
      User.stubs(:find).returns(user)
      O2::AdPublications::CrossSaleFinder.any_instance.stubs(
        results: cross_sales,
        total_clients: 2,
        total_value: 123,
        total_amount: 234,
        total_unpaid: 345,
      )
      O2::AdPublication.stubs(for_edition_ids_by_client: [])
      Edition.stubs(
        for_pub_ids: edition_dates,
        for_directors: edition_dates,
        report_by_pub_ids_ad_and_date: editions,
        report_by_pub_ids_and_date: editions,
      )
    end
    after do
      travel_back
    end

    describe "rendering" do
      context "multi edition mode" do
        it "shows 3 cards with headers in multi edition mode" do
          result = render_inline(subject).to_html

          assert_match "Ads Report", result
          assert_match "Paid Clients (0)", result
          assert_match "Unpaid Clients (0)", result
        end
      end
    end

    describe "motions" do
      it { assert_motion subject, :select_date }
      it { assert_motion subject, :select_publication }
      it { assert_motion subject, :select_all }
      it { assert_motion subject, :select_sort }

      describe "#select_date" do
        it "sets date" do
          assert_equal "2020-10-01", subject.date.to_s
          run_motion subject, :select_date, motion_event(target: { value: "2020-09-01" })
          assert_equal "2020-09-01", subject.date.to_s
        end
      end

      describe "#select_publication" do
        it "adds the edition's pub id to the set of selected pubs" do
          assert_equal [], subject.selected_pub_ids

          run_motion(
            subject,
            :select_publication,
            motion_event(
              target: { attributes: { "data-id": 4 } },
            ),
          )

          assert_equal [4], subject.selected_pub_ids
        end
      end

      describe "#select_all" do
        it "adds all edition publication_ids to the set of selected pubs" do
          assert_equal [], subject.selected_pub_ids

          run_motion subject, :select_all

          assert_equal [pub1.id, pub2.id], subject.selected_pub_ids
        end
      end

      describe "#select_sort" do
        it "sets sort options" do
          sort = subject.sort
          assert_equal "name", sort.col
          assert_equal "asc", sort.dir

          run_motion(
            subject,
            :select_sort,
            motion_event(
              target: {
                attributes: {
                  "data-col": "publication",
                  "data-dir": "asc",
                },
              },
            ),
          )

          sort = subject.sort
          assert_equal "publication", sort.col
          assert_equal "asc", sort.dir
        end
      end
    end

    describe "#paid_total_value" do
      before { subject.stubs(paid_ads: [stub(value: 2), stub(value: 3)]) }
      it { assert_equal 5, subject.paid_total_value }
    end
  end
end
# rubocop:enable Metrics/ClassLength
