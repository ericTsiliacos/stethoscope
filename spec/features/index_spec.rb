require_relative '../spec_helper'
require_relative '../request_helpers'

describe '/' do
  include RequestHelpers

  it 'displays a friendly message' do
    visit '/'

    expect(page).to have_text 'Welcome to Stethoscope'
  end

  it 'displays the last known cpu usage' do
    data = {
      series: [
        {
          metric: "bosh.healthmonitor.system.cpu.user",
          points: [
            [1456458457, 0.2]
          ],
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

    post data

    visit '/'

    expect(page).to have_text '0.2'
  end
end
