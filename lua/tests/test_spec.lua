local function assert_table_equals(expected, actual)
    for i = 1, #actual do
        if actual[i] ~= expected[i] then
            assert.equals(actual[i], expected[i])
        end
    end

    if #actual ~= #expected then
        assert(false, "" .. #actual .. " not equal to " .. #expected)
    end
end

describe("lifetrak functions", function()
    it("test init & _get_disk_config", function()
        local expected = {
            journals = {
                {
                    file = 'one',
                    current_index = 1730,
                },
                {
                    file = 'two',
                    current_index = 0,
                }
            },

            metas = {'thing', 'thong',},
        }

        require('lifetrak').init(expected)
        assert_table_equals(expected, require('lifetrak')._get_disk_config())
    end)

    it("test _get_json_file_name", function()
        local expected = '/home/hughie/.local/share/nvim/lifetrak.json'
        assert_table_equals(expected, require('lifetrak')._get_json_file_name())
    end)
end)
