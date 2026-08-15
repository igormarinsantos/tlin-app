import ApiClient from './ApiClient';

class TlinCopilotApi extends ApiClient {
  constructor() {
    super('tlin_copilot', { accountScoped: true });
  }

  suggest(data) {
    return this.create(data);
  }
}

export default new TlinCopilotApi();
