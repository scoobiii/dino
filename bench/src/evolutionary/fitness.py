def fitness(tokens: list, target_len: int = None, speed: float = 1.0) -> float:
    accuracy = 1.0 - abs(len(tokens) - (target_len or len(tokens))) / max(len(tokens),1)
    return accuracy * speed
