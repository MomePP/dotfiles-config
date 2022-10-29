local status_ok, obsidian = pcall(require, 'obsidian')
if not status_ok then return end

obsidian.setup {
    dir = '~/Documents/Obsidian-Vault/',
    completion = {
        nvim_cmp = true, -- if using nvim-cmp, otherwise set to false
    }
}
