require_relative '../spec_helper'
require_relative '../request_helpers'

describe 'filtering' do
  include RequestHelpers

  describe 'by time range' do
    it 'displays the average cpu usage between the specified range (inclusive)' do
      visit '/'

      events = [
        createEvent([1456458457, 1]),
        createEvent([1456458458, 2]),
        createEvent([1456458459, 3]),
        createEvent([1456458460, 21321])
      ]

      events.each { |data| post data }

      fill_in 'Start', with: '1456458457'
      fill_in 'End', with: '1456458459'
      click_on 'Filter'

      expect(page).to have_text '2'
    end
  end
end

def createEvent(point)
  data = {
    series: [
      {
        metric: "bosh.healthmonitor.system.cpu.user",
        points: [ point ],
        type: "gauge",
        host: nil,
        device: nil,
        tags: [
          "job:worker_cpi",
          "index:10",
          "deployment:project",
          "agent:8440617 f - d298 - 4 fa1 - 8 f94 - 1177 bcf513d7"
        ]
      }
    ]
  }
end
