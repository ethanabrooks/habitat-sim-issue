import itertools
import habitat


env = habitat.Env(config=habitat.get_config("config.yaml"))
for i in itertools.count():
    print(i)
    env.reset()
    done = False
    while not done:
        action = env.action_space.sample()
        try:
            env.step(action)
        except Exception:
            pass
        done = env.episode_over
