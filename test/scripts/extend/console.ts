import Console from '../../../lib/extend/console';
import chai from 'chai';
const should = chai.should();

describe('Console', () => {
  const ctx = {};
  it('register()', () => {
    const c = new Console();

    // no name
    // @ts-expect-error
    should.throw(() => c.register(), TypeError, 'name is required');

    // name, fn
    c.register('test', () => {});

    c.get('test').should.exist;

    // name, not fn
    // @ts-expect-error
    should.throw(() => c.register('test'), TypeError, 'fn must be a function');

    // name, desc, fn
    c.register('test', 'this is a test', () => {});

    c.get('test').should.exist;

    c.get('test').desc!.should.eql('this is a test');

    // name, desc, not fn
    // @ts-expect-error
    should.throw(() => c.register('test', 'this is a test'), TypeError, 'fn must be a function');

    // name, options, fn
    c.register('test', {init: true}, () => {});

    c.get('test').should.exist;
    c.get('test').options!.init!.should.be.true;

    // name, desc, options, fn
    c.register('test', 'this is a test', {init: true}, () => {});

    c.get('test').should.exist;
    c.get('test').desc!.should.eql('this is a test');
    c.get('test').options!.init!.should.be.true;

    // name, desc, options, not fn
    // @ts-expect-error
    should.throw(() => c.register('test', 'this is a test', {init: true}), TypeError, 'fn must be a function');
  });

  it('register() - alias', () => {
    const c = new Console();

    c.register('test', () => {});

    c.alias.should.eql({
      t: 'test',
      te: 'test',
      tes: 'test',
      test: 'test'
    });
  });

  it('register() - promisify', () => {
    const c = new Console();

    c.register('test', (args, callback) => {
      args.should.eql({foo: 'bar'});
      callback && callback(null, 'foo');
    });

    c.get('test').call(ctx, {
      _: [],
      foo: 'bar'
    }).then(result => {
      result.should.eql('foo');
    });
  });

  it('list()', () => {
    const c = new Console();

    c.register('test', () => {});

    c.list().should.have.all.keys(['test']);
  });

  it('get()', () => {
    const c = new Console();

    c.register('test', () => {});

    c.get('test').should.exist;
    c.get('t').should.exist;
    c.get('te').should.exist;
    c.get('tes').should.exist;
  });
});
