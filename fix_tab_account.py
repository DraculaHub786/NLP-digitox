with open('lib/ui/screens/settings/account/tab_account.dart', 'r') as f:
    content = f.read()

# Find the _buildProfileSection method and remove it
start = content.find('  Widget _buildProfileSection(ColorScheme colorScheme) {')
if start != -1:
    end = content.find('  /// Reusable responsive card builder that avoids overflow by using compact padding.', start)
    if end != -1:
        content = content[:start] + content[end:]
        print('Removed _buildProfileSection method')

# Find and remove _ProfilePicWidget class
start = content.find('/// Profile pic widget for account screen\nclass _ProfilePicWidget extends StatelessWidget {')
if start != -1:
    brace_count = 0
    in_class = False
    end_pos = -1
    for i in range(start, len(content)):
        if content[i] == '{':
            brace_count += 1
            in_class = True
        elif content[i] == '}':
            brace_count -= 1
            if in_class and brace_count == 0:
                end_pos = i + 1
                break
    if end_pos != -1:
        content = content[:start] + content[end_pos:]
        print('Removed _ProfilePicWidget class')

with open('lib/ui/screens/settings/account/tab_account.dart', 'w') as f:
    f.write(content)
print('Done')
