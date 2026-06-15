module.exports = {
  types: [
    { value: 'feat', name: 'feat:      A new feature' },
    { value: 'fix', name: 'fix:       A bug fix' },
    { value: 'docs', name: 'docs:      Documentation only changes' },
    { value: 'style', name: 'style:     Formatting, missing semi-colons, etc' },
    { value: 'refactor', name: 'refactor:  A code change that neither fixes a bug nor adds a feature' },
    { value: 'perf', name: 'perf:      A code change that improves performance' },
    { value: 'test', name: 'test:      Adding missing tests' },
    { value: 'chore', name: 'chore:     Changes to build process or auxiliary tools' },
    { value: 'revert', name: 'revert:    Revert to a previous commit' },
    { value: 'ci', name: 'ci:        Changes to CI configuration' },
    { value: 'WIP', name: 'WIP:       Work in progress' },
  ],

  scopes: [],

  messages: {
    type: "Select the type of change that you're committing:",
    scope: 'Denote the SCOPE of this change (optional):',
    customScope: 'Denote the SCOPE of this change:',
    subject: 'Write a SHORT, IMPERATIVE tense description of the change:\n',
    body: 'Provide a LONGER description of the change for the Summary section (use "|" for new lines):\n',
    breaking: 'List any BREAKING CHANGES (optional):\n',
    confirmCommit: 'Are you sure you want to proceed with the commit above?',
  },

  allowCustomScopes: true,
  allowBreakingChanges: ['feat', 'fix'],
  subjectLimit: 72,
  breaklineChar: '|',

  additionalQuestions: [
    {
      type: 'input',
      name: 'testPlan',
      message: 'Test Plan — how did you verify this change? (use "|" for new lines):\n',
    },
    {
      type: 'input',
      name: 'reviewers',
      message: 'Reviewers — @mention reviewers (optional, comma-separated):\n',
    },
    {
      type: 'input',
      name: 'subscribers',
      message: 'Subscribers — @mention subscribers (optional, comma-separated):\n',
    },
  ],

  formatMessageCB: function (answers) {
    var wrap = require('word-wrap');
    var wrapOptions = { trim: true, newline: '\n', indent: '', width: 72 };

    // Title line: type(scope): subject  OR  type: subject
    var head = answers.type;
    if (answers.scope) {
      head += '(' + answers.scope.trim() + '): ';
    } else {
      head += ': ';
    }
    head += answers.subject.trim();

    // Summary section from body answer
    var bodyWrapped = '';
    if (answers.body) {
      bodyWrapped = wrap(answers.body.split('|').join('\n').trim(), wrapOptions);
    }

    // Test Plan section
    var testPlanWrapped = '';
    if (answers.testPlan) {
      testPlanWrapped = wrap(answers.testPlan.split('|').join('\n').trim(), wrapOptions);
    }

    // Reviewers / Subscribers (optional)
    var reviewersLine = (answers.reviewers || '').trim();
    var subscribersLine = (answers.subscribers || '').trim();

    // Breaking changes
    var breakingWrapped = '';
    if (answers.breaking) {
      breakingWrapped = wrap(answers.breaking.split('|').join('\n').trim(), wrapOptions);
    }

    // Assemble
    var result = head;

    result += '\n\nSummary:\n' + (bodyWrapped || head);

    result += '\n\nTest Plan:\n' + (testPlanWrapped || 'Manual testing');

    if (reviewersLine) {
      result += '\n\nReviewers:\n' + reviewersLine;
    }

    if (subscribersLine) {
      result += '\n\nSubscribers:\n' + subscribersLine;
    }

    if (breakingWrapped) {
      result += '\n\nBREAKING CHANGE:\n' + breakingWrapped;
    }

    return result;
  },
};
